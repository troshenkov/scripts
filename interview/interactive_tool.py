#!/usr/bin/python3

import random

""""
--- Apple ---

Interactive Tool

Develop an interactive tool to capture User’s responses to pre-defined questions (10 multiple choice questions).
Application should ask questions to the User with 4 choices to choose answer from, and User will either provide 
a response or User will quit the process. Up on completion of 10 questions or User’s quit action - whichever is first, 
show Question and Responses the User has provided.
- 10 questions will be pre-defined - with 4 choices to select an answer from
- Application will not ask these questions in a serialized manner (or reverse order)
- Define 10 questions with 4 allowed answers in the data format you are comfortable with
"""

q1 = "1.1  ________ is the physical aspect of the computer that can be seen. \
    \nA. Hardware           \
    \nB. Software           \
    \nC. Operating system   \
    \nD. Application program\
    "
a1 = 'A'

q2 = "1.2  __________ is the brain of a computer.   \
    \nA. Hardware                                   \
    \nB. CPU                                        \
    \nC. Memory                                     \
    \nD. Disk                                       \
    "
a2 = 'B'

q3 = "1.3  The speed of the CPU may be measured in __________.  \
    \nA. megabytes                                              \
    \nB. gigabytes                                              \
    \nC. megahertz                                              \
    \nD. gigahertz                                              \
    "
a3 = "C" # Correct answer D is not working at this moment

q4 = "1.4  Why do computers use zeros and ones?                                                                       \
    \nA. because combinations of zeros and ones can represent any numbers and characters.                             \
    \nB. because digital devices have two stable states and it is natural to use one state for 0 and the other for 1. \
    \nC. because binary numbers are simplest.                                                                         \
    \nD. because binary numbers are the bases upon which all other number systems are built.                          \
    "
a4 = 'B'

q5 = "1.5  One byte has ________ bits.  \
    \nA. 4                              \
    \nB. 8                              \
    \nC. 12                             \
    \nD. 16                             \
    "
a5 = 'B'

q6 = "1.6  One gigabyte is approximately ________ bytes.    \
    \nA. 1 million                                          \
    \nB. 10 million                                         \
    \nC. 1 billion                                          \
    \nD. 1 trillion                                         \
    "
a6 = 'C'

q7 = "1.7  A computer?s _______ is volatile; that is, any information stored in it is lost when the system?s power is turned off. \
    \nA. floppy disk    \
    \nB. hard disk      \
    \nC. flash stick    \
    \nD. CD-ROM         \
    \nE. memory         \
    "
a7 = 'E'

q8 = "1.8  Which of the following are storage devices?  \
    \nA. floppy disk                                    \
    \nB. hard disk                                      \
    \nC. flash stick                                    \
    \nD. CD-ROM                                         \
    "
a8 = 'A' # Correct answers B,C,D are not working at this moment

q9 = "1.9  ____________ is a device to connect a computer to a local area network (LAN). \
    \nA. Regular modem  \
    \nB. DSL            \
    \nC. Cable modem    \
    \nD. NIC            \
    "
a9 = 'D'

q10 = "1.10  ____________ are instructions to the computer. \
    \nA. Hardware                                           \
    \nB. Software                                           \
    \nC. Programs                                           \
    \nD. Keyboards                                          \
    "
a10 = 'B' #Correct answer C is not working at this moment


quests = [q1, q2, q3, q4, q5, q6, q7, q8, q9, q10]
answers = [a1, a2, a3, a4, a5, a6, a7, a8, a9, a10]

if len(quests) != len(answers):
    print("Incorrect data")
    exit(1)

for i in range(0, len(quests)):
    r = random.randrange(0, len(quests))
    print(quests[r])
    response = input('Chech Answer of Question or press Q for quit: ')

    if response == 'Q':
        exit(0)

    if response == answers[r]:
        print("Your answer is correct - V")
    else: print("Your answer A is incorrect - X")

exit(0)



