
	Log = Logs/ds_29_1.log
	Txt = Logs/ds_29_1.tx

%.exe : %.cpp
	$(CXX) -o $@ $^

# ------------------------------------------------
all : routes.exe
	getRoutes.k $(Log)
	# cat $(Txt)
	routes $(Log) | head -40

routes.txt : Logs/*.log
	getRoutes.k Logs/*.log | tee routes.txt 


