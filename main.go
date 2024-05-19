package main

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"strconv"
	"strings"

	"github.com/fatih/color"
)

func main() {
    scanner := bufio.NewScanner(os.Stdin)
    scriptsPath := "./scripts" // Path to the scripts folder

    bold := color.New(color.Bold)
    red := color.New(color.FgRed).Add(color.Bold)
    cyan := color.New(color.FgCyan).Add(color.Bold)
    green := color.New(color.FgGreen).Add(color.Bold)

    for {
        groups, err := os.ReadDir(scriptsPath)
        if err != nil {
            red.Println("Error reading scripts directory:", err)
            return
        }

        cyan.Println("\nSelect a group of scripts to view, or type 'quit' to exit:")
        for i, group := range groups {
            if group.IsDir() {
                fmt.Printf("  %d: %s\n", i+1, bold.Sprintf("%s", group.Name()))
            }
        }

        fmt.Print("Enter your choice: ")
        scanner.Scan()
        input := scanner.Text()
        if input == "quit" {
            red.Println("Exiting...")
            break
        }

        choice, err := strconv.Atoi(input)
        if err != nil || choice < 1 || choice > len(groups) {
            red.Println("Invalid input, please try again.")
            continue
        }

        selectedGroup := groups[choice-1]
        scripts, err := os.ReadDir(scriptsPath + "/" + selectedGroup.Name())
        if err != nil {
            red.Println("Error reading selected group directory:", err)
            continue
        }

        green.Println("\nAvailable scripts:")
        for i, script := range scripts {
            if !script.IsDir() {
                fmt.Printf("  %d: %s\n", i+1, script.Name())
            }
        }

        fmt.Print("Select a script to run, or type 'back' to return to group selection: ")
        scanner.Scan()
        scriptInput := scanner.Text()
        if scriptInput == "back" {
            continue
        }

        scriptChoice, err := strconv.Atoi(scriptInput)
        if err != nil || scriptChoice < 1 || scriptChoice > len(scripts) {
            red.Println("Invalid input, please try again.")
            continue
        }

        selectedScript := scripts[scriptChoice-1]

        // Ask for parameters
        fmt.Print("Enter parameters for the script (if any): ")
        scanner.Scan()
        parameters := scanner.Text()
        params := strings.Fields(parameters) // Split parameters into a slice

        green.Printf("\nRunning script: %s with parameters %s\n", selectedScript.Name(), parameters)
        cmd := exec.Command("bash", append([]string{scriptsPath + "/" + selectedGroup.Name() + "/" + selectedScript.Name()}, params...)...)
        cmd.Stdout = os.Stdout
        cmd.Stderr = os.Stderr
        if err := cmd.Run(); err != nil {
            red.Println("Error running script:", err)
            continue
        }

        green.Println("Script executed successfully.")
    }
}
