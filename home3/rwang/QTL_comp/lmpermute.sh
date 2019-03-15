#Richard's computer
#run lmpermute with vars
GSL_RNG_TYPE="taus" GSL_RNG_SEED=122 ./lmpermute 14600 17800 4 &
GSL_RNG_TYPE="taus" GSL_RNG_SEED=88 ./lmpermute 17800 20996 5 &
