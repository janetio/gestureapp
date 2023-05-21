import os

confirm = input("are you sure you want to continue running fixcsv.py? (y/n)")
if(confirm != 'y'):
    quit()

csv_folders_path = "project recordings"

os.chdir(csv_folders_path)
for i in os.listdir():
    os.chdir(i)
    for csv in os.listdir():
        lines = []
        if(csv == ".DS_Store"):
            os.remove(csv)
        with open(csv, "r") as f:
            lines = f.readlines()
            lines[0] = lines[0].replace("udeX", "attitudeX")
        with open(csv, "w+") as f:
            f.writelines(lines)
    os.chdir("..")