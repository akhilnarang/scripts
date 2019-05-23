#!/usr/bin/env python3

from sys import argv

if len(argv) != 2:
    print("Usage: {} <codename>".format(argv[0]))
    exit(1)

testers = {
    'berkeley': ('srisurya95'),
    'beryllium': ('akhilnarang', 'grewal'),
    'bullhead': ('anirudhgupta109', 'Skittles8923'),
    'cheeseburger': ('HydroPetro', 'fryevia'),
    'crosshatch': ('XlxFoXxlX'),
    'dipper': ('argraur'),
    'dumpling': ('divadsn', 'HydroPetro'),
    'enchilada': ('anirudhgupta109'),
    'fajita': ('nezorflame'),
    'kiwi': ('coldhans'),
    'mata': ('KuranKaname', 'XlxFoXxlX', 'Y45HW4N7'),
    'mido': ('Adesh15'),
    'oneplus3': ('HydroPetro', 'theshinybeast'),
    'platina': ('nysadev'),
    'potter': ('NickvBokhorst'),
    'whyred': ('akhilnarang', 'iwantz', 'raiadventures', 'ahmed_tohamy', 'MSFJarvis', 'Sanchith_Hegde', 'ai94iq', 'anunaym14_bot', 'bohrabhijeet', 'ZTR23'),
    'x2': ('moto999999'),
    'z2_plus': ('kenny3fcb', 'Pavan_Paps'),
    'zl1': ('Gabronog')
}

device = argv[1]

message = ""

if device in testers.keys():
    for tester in testers[device]:
        message += '@{} '.format(tester)
    print(message)
else:
    print("Wrong device {}(?)".format(device))
