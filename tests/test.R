# vim: set ts=2 sw=2 expandtab:

install.packages("logMsg_0.1.tar.gz")

library(parallel)
library(shaRNG)
library(logMsg)

#hosts <- rep(c('localhost'), 2)
#print(hosts)
# cl <- makeCluster(hosts, manual=TRUE)
# cl <- makeCluster(hosts, rshcmd = "./tests/ssh.sh")
# cl <- makeCluster(hosts)
cl <- makeCluster(2)

setDefaultCluster(cl)

logMsg.setup(cl, "./logs")

if (TRUE) {

  RNG.set.seed.state("132433")
  RNG.sync(cl)

  {

    clusterEvalQ(cl, logMsg("lapply"))

    "rnorm9" %RNG.split.eval% {
      lapply(1:9, function(i)
             {
               i %RNG.split.eval% {
                 logMsg(paste(i, rnorm(2)))
               }
             })
    }

    clusterEvalQ(cl, logMsg("parLapply"))

    parLapply(cl, 1:9, function(i)
              {
                "rnorm9" %RNG.split.eval% {
                  i %RNG.split.eval% {
                    logMsg(paste(i, rnorm(2)))
                  }
                }
              })

    clusterEvalQ(cl, logMsg("parLapply"))

    "rnorm9" %RNG.split.eval% {
      RNG.sync(cl)
      parLapply(cl, 1:9, function(i)
                {
                  i %RNG.split.eval% {
                    logMsg(paste(i, rnorm(2)))
                  }
                })
    }

    invisible(NULL)

  }

}

TestParRNG <- function() {
  require(shaRNG)
  RNG.set.seed.state("132433")
  RNG.jump("rnorm9")
  n <- 9
  sub.states <- GetSplitStates(n)$sub.states

  result.par <- parSapply(cl, 1:n, function(i) {
                          require(shaRNG)
                          RNG.set.state(sub.states[[i]])
                          # logMsg(sub.states[[i]])
                          # logMsg(sub.states[[i]])
                          return(rnorm(2))
                })
  print(result.par)

  result <- sapply(1:n, function(i) {
                   require(shaRNG)
                   RNG.set.state(sub.states[[i]])
                   return(rnorm(2))
                })
  print(result)
}

TestParRNG()

sup.test.export <- function() {
  sa <- 100
  test.export <- function() {
    a <- 10
    parLapply(cl, 1:4, function(i) { logMsg(paste(i)) })
    parLapply(cl, 1:4, function(i) { logMsg(paste(a,i)) })
    parLapply(cl, 1:4, function(i) { logMsg(paste(sa,a,i)) })
    invisible(NULL)
  }
  test.export
}

sup.test.export()()
