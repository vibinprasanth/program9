# pro-9Port-Based Firewall Configuration
Aim

Configure a Linux firewall to open and close specific TCP ports using firewall-cmd.

Learning Objectives

By completing this assignment, you should be able to:

Understand the purpose of network ports.
Use firewall-cmd to open a TCP port.
List currently configured ports.
Remove an open port.
Configure a permanent firewall rule.
Reload the firewall configuration.
Write a Bash script to automate firewall configuration.
Background

Ports are logical communication endpoints used by network services.

Some commonly used ports are:

Port	Protocol	Common Service
22	TCP	SSH
80	TCP	HTTP
443	TCP	HTTPS
8080	TCP	Custom HTTP
9000	TCP	Custom Application

In this assignment, you will work with custom TCP ports.

Commands to Learn

The following commands are relevant to this assignment:

firewall-cmd --add-port=8080/tcp
firewall-cmd --add-port=9000/tcp
firewall-cmd --list-ports
firewall-cmd --remove-port=8080/tcp
firewall-cmd --add-port=3000/tcp --permanent
firewall-cmd --reload

Student Task

Complete the script:

starter/firewall_config.sh


Your script must perform the following operations in order.

Requirement 1 — Open Port 8080

Open TCP port 8080.

Expected operation:

firewall-cmd --add-port=8080/tcp

Requirement 2 — Open Port 9000

Open TCP port 9000.

Expected operation:

firewall-cmd --add-port=9000/tcp

Requirement 3 — List Ports

Display the currently configured ports.

Expected operation:

firewall-cmd --list-ports

Requirement 4 — Remove Port 8080

Remove TCP port 8080.

Expected operation:

firewall-cmd --remove-port=8080/tcp

Requirement 5 — Permanently Open Port 3000

Add TCP port 3000 as a permanent firewall rule.

Expected operation:

firewall-cmd --add-port=3000/tcp --permanent

Requirement 6 — Reload the Firewall

Reload the firewall configuration.

Expected operation:

firewall-cmd --reload

Expected Final State

After the script completes:

8080/tcp should not be present as a runtime port.
9000/tcp should be present as a runtime port.
3000/tcp should be present as a permanent port.
The firewall should be reloaded.
Important

For this GitHub assignment, do not attempt to modify the real firewall on the GitHub Actions runner.

The automated tests provide a mock firewall-cmd command.

Your script should therefore call:

firewall-cmd


normally. Do not hard-code a path such as:

/usr/bin/firewall-cmd

Script Requirements

Your script should:

Use Bash.
Be executable.
Use firewall-cmd.
Perform all six required operations.
Execute the operations in the required order.
Exit with status code 0 when successful.

A recommended script structure is:

#!/bin/bash

# Your solution goes here


You may add comments to explain your work.

What Not To Do

Do not:

Modify the GitHub Actions workflow.
Modify the test files.
Modify the autograder.
Delete required files.
Hard-code test output.
Create a fake firewall-cmd command in your submission.
Use /usr/bin/firewall-cmd directly.
Testing Locally

If you have a Linux system with Bash installed, you can check your script syntax with:

bash -n starter/firewall_config.sh


You can also make the script executable:

chmod +x starter/firewall_config.sh


The complete automated evaluation will run through GitHub Actions.

Submission

Commit and push your completed solution:

git add .
git commit -m "Complete firewall configuration"
git push


GitHub Actions will automatically run the tests.

Grading
Requirement	Marks
Open port 8080	15
Open port 9000	15
List ports	10
Remove port 8080	15
Permanently open port 3000	20
Reload firewall	15
Correct Bash/executable script	10
Total	100
Academic Integrity

Write your own solution. You may use the Linux firewall-cmd documentation and Bash documentation for reference.

Do not modify the provided tests or grading infrastructure.
