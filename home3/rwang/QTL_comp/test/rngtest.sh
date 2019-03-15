#run the rngtest with environment vars
export GSL_RNG_TYPE="taus" 
export GSL_RNG_SEED=123 
./rngtest

#or we could just run it like this
#GSL_RNG_TYPE="taus" GSL_RNG_SEED=123 ./rngtest
