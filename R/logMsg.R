# vim: set ts=2 sw=2 expandtab:

.onLoad <- function(lib, pkg) {
  if (!exists("logMsg")) {
    assign("logMsg.counter", 0, envir = .GlobalEnv)
    assign("logMsg", function(msg)
           {
             logMsg.counter <- logMsg.counter + 1
             tmsg = paste(strptime(Sys.time(), format = "%F%T"),
                          ":",
                          logMsg.counter,
                          ":",
                          msg)
             print(tmsg)
           }, envir = .GlobalEnv)
    logMsg("logMsg sourced")
  }
}

logMsg.setup <- function(cl, logDir) {
  dir.create(logDir, recursive = TRUE, mode = "0755")
  assign("logMsg.cl", cl, envir = .GlobalEnv)
  assign("logMsg.counter", 0, envir = .GlobalEnv)
  assign("logMsg.filename", logDir, envir = .GlobalEnv)
  assign("logMsg.machine", 0, envir = .GlobalEnv)
  assign("logMsg", function(msg, append = TRUE)
         {
           assign("logMsg.counter", logMsg.counter + 1, envir = .GlobalEnv)
           tmsg = paste(strptime(Sys.time(), format = "%F%T"),
                        logMsg.machine,
                        ":",
                        logMsg.counter,
                        ":",
                        toString(msg))
           write(tmsg, logMsg.filename, append = append)
           if (logMsg.machine == 0) {
             print(tmsg);
           }
         }, envir = .GlobalEnv)

  print("logMsg local function initialized")

  clusterExport(cl,
                c('logMsg', 'logMsg.filename', 'logMsg.machine', 'logMsg.counter'),
                environment())

  print("logMsg remote function initialized")

  logMsg.filename.new <- paste(logMsg.filename, "0", sep="/")
  assign("logMsg.filename", logMsg.filename.new, envir = .GlobalEnv)
  print("logMsg local function setup")

  clusterApply(cl, 1:length(cl), function(index)
               {
                 logMsg.filename.new <- paste(logMsg.filename, index, sep="/")
                 assign("logMsg.filename", logMsg.filename.new, envir = .GlobalEnv)
                 assign("logMsg.machine", index, envir = .GlobalEnv)
                 return(logMsg.filename)
               })
  print("logMsg remote function setup")

  clusterCall(cl, function(cwd)
              {
                setwd(cwd)
                logMsg("logMsg Setup Done")
                logMsg(getwd())
              }, getwd())
  logMsg("logMsg Setup Done")
  logMsg(getwd())
}

logMsg.clear <- function(msg = "Msg cleared.") {
  logMsg(msg, append=F)
  clusterCall(logMsg.cl, logMsg, msg, append=F)
}
