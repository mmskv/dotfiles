package main

import (
	"errors"
	"fmt"
	"math"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strconv"
	"strings"
	"time"
)

const (
	workDur  = 25 * time.Minute
	restDur  = 5 * time.Minute
	bigDur   = 15 * time.Minute
	maxCycle = 4
)

type phase string

const (
	phaseWork    phase = "W"
	phaseRest    phase = "R"
	phaseBigRest phase = "B"
)

type state struct {
	phase    phase
	end      time.Time
	interval int
}

func stateFile() string {
	return filepath.Join(os.Getenv("HOME"), ".cache", "pm", "state")
}

func notify(title, body string) {
	var cmd *exec.Cmd
	switch runtime.GOOS {
	case "darwin":
		cmd = exec.Command("terminal-notifier", "-title", title, "-message", body)
	case "linux":
		cmd = exec.Command("notify-send", "-a", "pm", title, body)
	default:
		return
	}
	_ = cmd.Run()
}

func read() (*state, error) {
	data, err := os.ReadFile(stateFile())
	if err != nil {
		return nil, err
	}
	parts := strings.Fields(string(data))
	if len(parts) != 3 {
		return nil, errors.New("invalid state")
	}
	endUnix, err := strconv.ParseInt(parts[1], 10, 64)
	if err != nil {
		return nil, err
	}
	interval, err := strconv.Atoi(parts[2])
	if err != nil {
		return nil, err
	}
	return &state{
		phase:    phase(parts[0]),
		end:      time.Unix(endUnix, 0),
		interval: interval,
	}, nil
}

func write(s *state) error {
	path := stateFile()
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return err
	}
	data := fmt.Sprintf("%s %d %d\n", s.phase, s.end.Unix(), s.interval)
	return os.WriteFile(path, []byte(data), 0o644)
}

func running() bool {
	_, err := os.Stat(stateFile())
	return err == nil
}

func start() {
	if running() {
		return
	}
	s := &state{phase: phaseWork, end: time.Now().Add(workDur), interval: 1}
	if err := write(s); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	notify("pm", "Work 1/4 — 25 min")
}

func stop() {
	if !running() {
		return
	}
	os.Remove(stateFile())
	notify("pm", "Stopped")
}

func toggle() {
	if running() {
		stop()
	} else {
		start()
	}
}

func advance(s *state) {
	switch s.phase {
	case phaseWork:
		if s.interval >= maxCycle {
			s.phase = phaseBigRest
			s.end = s.end.Add(bigDur)
			notify("pm", "Big rest — 15 min")
		} else {
			s.phase = phaseRest
			s.end = s.end.Add(restDur)
			notify("pm", "Rest — 5 min")
		}
	case phaseRest:
		s.interval++
		s.phase = phaseWork
		s.end = s.end.Add(workDur)
		notify("pm", fmt.Sprintf("Work %d/4 — 25 min", s.interval))
	case phaseBigRest:
		s.phase = phaseWork
		s.interval = 1
		s.end = s.end.Add(workDur)
		notify("pm", "Work 1/4 — 25 min")
	}
}

func tick() {
	s, err := read()
	if err != nil {
		return
	}
	now := time.Now()
	for !now.Before(s.end) {
		advance(s)
	}
	if err := write(s); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	remaining := int(math.Ceil(s.end.Sub(now).Minutes()))
	if s.phase == phaseWork {
		fmt.Printf("W %d\n", remaining)
	} else {
		fmt.Println("R")
	}
}

func main() {
	if len(os.Args) < 2 {
		usage()
	}
	switch os.Args[1] {
	case "start":
		start()
	case "stop":
		stop()
	case "toggle":
		toggle()
	case "tick":
		tick()
	default:
		usage()
	}
}

func usage() {
	fmt.Fprintln(os.Stderr, "usage: pm {start|stop|toggle|tick}")
	os.Exit(1)
}
