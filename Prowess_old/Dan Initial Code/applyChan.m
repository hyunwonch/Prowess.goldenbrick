function sig = applyChan(sigIn,chan)

sig = sqrt(chan.power) * filter(chan.firTap,1,sigIn) ;