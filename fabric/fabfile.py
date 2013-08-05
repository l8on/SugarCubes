from fabric.api import run,env,task,sudo,cd

env.user = 'sugarcubes'
env.password = 'sugarcubes'
env.hosts = ['192.168.1.28']

@task
def startBoard():
	with cd('Desktop/SC_PB'):
		sudo('./xc_PB 640 160 160 1000')

@task
def loadModule():
	with cd('enable_arm_pmu-master'):
		sudo('./load-module')

@task
def stopBoard():
	sudo("ps -axcopid,command | grep \"xc_PB\" | awk '{ system(\"kill -9 \"$1) }'")

@task
def restartBoard():
	stopBoard()
	startBoard()

#loadModule startBoard