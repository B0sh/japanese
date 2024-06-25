import os
import time

dir = os.path.dirname(os.path.realpath(__file__))

# os.system(f'killall "Audio Hijack"')

def runScript(file_name, output = False):
    os.system(f'open -g -h -b com.rogueamoeba.audiohijack {dir}/{file_name}')

    if output == True:
        time.sleep(0.5)
        with open(dir + "/output", "r") as file:
            file_contents = file.read().strip()
            return file_contents
    return True


runScript('start.ahcommand')
time.sleep(2)

last_result = None
for i in range(0, 60):
    result = runScript('check.ahcommand', True)
    print(result)

    if last_result == result:
        print("Identical result")
        break
        
    last_result = result

