#Implementation of basic Z+A 2015 model just to make sure I remember
#exactly what I'm doing here

#Graham Northrup June 30

NUMDAYS <- 60
dt <- 0.05
NUMSTEPS <- NUMDAYS/dt
Hf <- rep(0, NUMSTEPS) #free antigen
Hb <- rep(0, NUMSTEPS) #bound antigen
B <- rep(0, NUMSTEPS) #B cells
A <- rep(0, NUMSTEPS) #Antibodies
t <- seq(0, NUMDAYS, dt) #time vector

k <- 0.01 #1/AU*day
dH <- 0.5 #1/day
dB <- 3 #1/day USE FOR ACM 
s <- 1 #1/day
phi <- #AU
a <- 0.1 #1/day
dA <- 0.1 #1/dat
alpha <- 0.01 #USE FOR FIM

Hf[1] <- 1000
B[1] <- 1
A[1] <- 1

HfFUNC <- function(k,dH,A,Hf,t) { #evaluates dHf/dt at given values and time
  return(-k*A[t]*Hf[t] - dH*Hf[t])
}

HbFUNC <- function(k,dH,A,Hf,Hb,t) { #evals Hb ODE
  return(k*A[t]*Hf[t] - dH*Hb[t])
}

BFUNCMask <- function(s,phi,B,Hf,Hb,t) { #B cell ODE
  return((s*B[t]*Hf[t])/(phi + Hf[t]))
}

BFUNCNonMask <- function(s,phi,B,Hf,Hb,t) { #B cell ODE. Also causes weird dynamics
  H <- Hf[t] + Hb[t]
  return((s*B[t]*H)/(phi + H))
}

AFUNC <- function(k,dA,a,B,Hf,A,t) { #Ab ODE
  return(a*B[t] - k*A[t]*Hf[t] - dA*A[t])
}


#Forward Euler first because I want to make sure I'm
#in the right ballpark on this

for (i in 1:NUMSTEPS) {
  if (t[i] == 30) {
    Hf[i+1] = 1000
  } else {
    Hf[i+1] <- Hf[i] + dt*HfFUNC(k,dH,A,Hf,i)
  }
  Hb[i+1] <- Hb[i] + dt*HbFUNC(k,dB,A,Hf,Hb,i)
  B[i+1] <- B[i] + dt*BFUNCNonMask(s,phi,B,Hf,Hb,i)
  A[i+1] <- A[i] + dt*AFUNC(k,dA,a,B,Hf,A,i)
  if (Hf[i+1] < 0.0001) {
    Hf[i+1] <- 0
  }
  if (Hb[i+1] < 0.0001) {
    Hb[i+1] <- 0
  } else if (Hb[i+1] > 1000) {
    Hb[i+1] <- 1000
  }

}

plot(t ,Hf,type='l',col='red',log = 'y', xlim=c(0,60),ylim=c(1,100000000),xlab='Days',ylab='Count')
lines(t,B,type='l',col='blue')
lines(t,A,type='l',col='dark green')
lines(t,Hb,type='l', col='orange')

lines(t,Hf+Hb,type='l', col='purple')


