sps = 10^4


nRef = 40*10^9/(100*10^3)
nCOps = nRef * log2(nRef) * sps ;

nCGOps = nCOps/(10^9)

nWide = 40*10^9/(40*10^6)
nCGOpsWide = nWide * log2(nWide) * sps /(10^9)

nNarrow = 40*10^6/(100*10^3)
nCGOpsNarrow = nNarrow * log2(nNarrow) * sps /(10^9)

totCGOps = nCGOpsWide + nCGOpsNarrow

ratio = nCGOps / totCGOps

