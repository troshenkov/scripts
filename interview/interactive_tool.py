#!/usr/bin/env python3
#
# --- Apple ---
# Script: interactive_quiz.py
#
# Description:
#   This script implements two main functionalities:
#
#   1. Fetch and sort Billboard Hot 100 artists by the total number of letters
#      in their track titles. The chart can be found at:
#      https://www.billboard.com/charts/hot-100
#
#   2. Interactive Tool:
#      An interactive quiz that captures User’s responses to pre-defined multiple
#      choice questions. The quiz presents 10 questions with 4 choices each.
#      Questions are shown in a random order, and the user can quit at any time.
#      Upon completion or early exit, the script summarizes the responses.
#
# Requirements:
#   - Python 3.x
#   - Libraries:
#       - requests
#       - beautifulsoup4
#
# Usage:
#   To run the Billboard Hot 100 functionality (if implemented):
#       python3 interactive_quiz.py --mode billboard
#
#   To run the interactive quiz:
#       python3 interactive_quiz.py --mode quiz
#
# Author: Dmitry Troshenkov (troshenkov.d@gmail.com)
# Date: April 12, 2025
#
# -----------------------------------------------------------------------------
# Notes:
#   Interactive Tool Specification:
#
#   Develop an interactive tool to capture User’s responses to pre-defined questions (10 multiple choice questions).
#   Application should ask questions to the User with 4 choices to choose answer from, and User will either provide 
#   a response or quit the process. Upon completion of 10 questions or User’s quit action - whichever is first, 
#   show Question and Responses the User has provided.
#   - 10 questions will be pre-defined - with 4 choices to select an answer from
#   - Application will not ask these questions in a serialized manner (or reverse order)
#   - Define 10 questions with 4 allowed answers in the data format you are comfortable with
# -----------------------------------------------------------------------------

import random

# Define 10 questions with 4 or 5 choices each
questions = [
    {
        "question": "1.1  ________ is the physical aspect of the computer that can be seen.",
        "choices": ["Hardware", "Software", "Operating system", "Application program"]
    },
    {
        "question": "1.2  __________ is the brain of a computer.",
        "choices": ["Hardware", "CPU", "Memory", "Disk"]
    },
    {
        "question": "1.3  The speed of the CPU may be measured in __________.",
        "choices": ["megabytes", "gigabytes", "megahertz", "gigahertz"]
    },
    {
        "question": "1.4  Why do computers use zeros and ones?",
        "choices": [
            "because combinations of zeros and ones can represent any numbers and characters.",
            "because digital devices have two stable states and it is natural to use one state for 0 and the other for 1.",
            "because binary numbers are simplest.",
            "because binary numbers are the bases upon which all other number systems are built."
        ]
    },
    {
        "question": "1.5  One byte has ________ bits.",
        "choices": ["4", "8", "12", "16"]
    },
    {
        "question": "1.6  One gigabyte is approximately ________ bytes.",
        "choices": ["1 million", "10 million", "1 billion", "1 trillion"]
    },
    {
        "question": "1.7  A computer's _______ is volatile; that is, any information stored in it is lost when the system’s power is turned off.",
        "choices": ["floppy disk", "hard disk", "flash stick", "CD-ROM", "memory"]
    },
    {
        "question": "1.8  Which of the following are storage devices?",
        "choices": ["floppy disk", "hard disk", "flash stick", "CD-ROM"]
    },
    {
        "question": "1.9  ____________ is a device to connect a computer to a local area network (LAN).",
        "choices": ["Regular modem", "DSL", "Cable modem", "NIC"]
    },
    {
        "question": "1.10  ____________ are instructions to the computer.",
        "choices": ["Hardware", "Software", "Programs", "Keyboards"]
    }
]

# Shuffle questions
random.shuffle(questions)

# Store user answers
responses = []

print("Welcome to the Interactive Quiz Tool!")
print("Choose your answer (A/B/C/D/E), or type 'Q' to quit.\n")

for i, q in enumerate(questions):
    print(f"Q{i+1}: {q['question']}")
    for idx, choice in enumerate(q["choices"]):
        print(f"  {'ABCDE'[idx]}) {choice}")
    
    while True:
        answer = input("Your answer (A/B/C/D/E or Q to quit): ").strip().upper()
        if answer in 'ABCDE'[:len(q["choices"])]:
            responses.append((q["question"], q["choices"]['ABCDE'.index(answer)]))
            print()
            break
        elif answer == 'Q':
            print("\nQuitting the quiz early...\n")
            break
        else:
            print("Invalid input. Please enter one of A/B/C/D/E or Q.")

    if answer == 'Q':
        break

# Show summary
print("\n📋 Your Quiz Summary:")
for idx, (question, response) in enumerate(responses, 1):
    print(f"{idx}. {question}")
    print(f"   ➤ Your answer: {response}\n")