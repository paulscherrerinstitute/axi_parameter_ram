import os

os.chdir("../sim")

os.system("vsim -c -do ci.do")

with open("Transcript.transcript") as f:
	content = f.read()
	
#Expected Errors
if "###ERROR###" in content:
	exit(-1)
#Unexpected Errors
if "SIMULATIONS COMPLETED SUCCESSFULLY" not in content:
	exit(-2)
	
	
#Success
exit(0)