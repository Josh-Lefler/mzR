setMethod("get3Dmap",
          signature="mzRramp",
          function(object,scans,lowMz,highMz,resMz) 
          return(object@backend$get3DMap(scans,lowMz,highMz,resMz)))

setMethod("initializeRamp",
          signature="mzRramp",
          function(object) {
            if (!file.exists(fileName(object)))
                stop("File ", fileName(object), " not found.\n")
            object@backend$open(fileName(object), declaredOnly = TRUE)
            if (isInitialized(object)) invisible(TRUE)
            else stop("Could not initialize ramp slot.")
          })

setMethod("length",
          signature=c("mzRramp"),
          function(x) return(x@backend$getLastScan()))

setMethod("peaks", "mzRramp",
          function(object, scans) .peaks(object, scans))

setMethod("spectra", "mzRramp",
          function(object, scans) .peaks(object, scans))

setMethod("peaksCount",
          signature=c("mzRramp","numeric"),
          function(object,scans) {
              if (length(scans)==1) {
                  return(object@backend$getPeakList(scans)$peaksCount)
              } else {
                  return(sapply(scans,function(x) object@backend$getPeakList(x)$peaksCount))
              }
          })

setMethod("peaksCount",
          signature=c("mzRramp","missing"),
          function(object) {
              n <- length(object)
              return(peaksCount(object,1:n))
          })

setMethod("header",
          signature=c("mzRramp","missing"),
          function(object) {
              res <- object@backend$getAllScanHeaderInfo()
              res$spectrumId <- paste0("scan=", res$acquisitionNum)
              res
})


setMethod("header",
          signature=c("mzRramp","numeric"),
          function(object, scans) {
              if (length(scans)==1) {
                  res <- object@backend$getScanHeaderInfo(scans)
              } else {
                  res <- data.frame(t(sapply(scans, function(x)
                      unlist(object@backend$getScanHeaderInfo(x)))))
              }
              res$spectrumId <- paste0("scan=", res$acquisitionNum)
              res
          })

setMethod("close", 
          signature="mzRramp",
          function(con,...) return(con@backend$close()))

setMethod("isInitialized", 
          signature="mzRramp",
          function(object) return(object@backend$OK()))

setMethod("runInfo",
          signature="mzRramp",
          function(object) {
              ##return(object@backend$getRunInfo())
              hd <- header(object)
              ll <- list()
              ll$'scanCount' <- length(object)
              ll$'lowMz' <- min(hd$lowMZ)
              ll$'highMz' <- max(hd$highMZ)
              ll$'dStartTime' <- min(hd$retentionTime)
              ll$'dEndTime' <- max(hd$retentionTime)
              ll$'msLevels' <- unique(hd$msLevel)
              ll$'startTimeStamp' <- NA
              return(ll)
          })


setMethod("instrumentInfo",
          signature="mzRramp",
          function(object) 
              return(object@backend$getInstrumentInfo()))


setMethod("manufacturer",
          signature="mzRramp",
          function(object) {
              info <- instrumentInfo(object)           
              return(info$manufacturer)
          })

setMethod("model",
          signature="mzRramp",
          function(object) {
              info <- instrumentInfo(object)           
              return(info$model)
          })

setMethod("ionisation",
          signature="mzRramp",
          function(object) {
              info <- instrumentInfo(object)           
              return(info$ionisation)
          })

setMethod("analyzer",
          signature="mzRramp",
          function(object) {
              info <- instrumentInfo(object)           
              return(info$analyzer)
          })

setMethod("detector",
          signature="mzRramp",
          function(object) {
              info <- instrumentInfo(object)           
              return(info$detector)
          })


setMethod("show",
          signature="mzRramp",
          function(object) {
              if (!isInitialized(object)) {
                  cat("Your object's ramp slot is not initialized.\n")
                  cat("Use initializeRamp(object) to fix this.\n")
              } else {
                  filename <- fileName(object)
                  ## info <- instrumentInfo(object)
                  ## run  <- runInfo(object)
                  cat("Mass Spectrometry file handle.\n")
                  cat("Filename: ", basename(filename), "\n")
                  cat("Number of scans: ", length(object), "\n")
                  ## if (any(info != "")) {
                  ##   cat("Manufacturer: ", info$manufacturer, "\n")
                  ##   cat("Model:        ", info$model, "\n")
                  ##   cat("Ionisation:   ", info$ionisation, "\n")
                  ##   cat("Analyzer:     ", info$analyzer, "\n")
                  ##   cat("Detector:     ", info$detector, "\n")
                  ## }
                  ## cat("Number of scans: ", run$scanCount, "\n")
                  ## cat("lowMZ:        ", run$lowMZ, " \thighMZ: ", run$highMZ, "\n")
                  ## cat("startMZ:      ", run$startMZ, " \tendMZ: ",  run$endMZ, "\n")
                  ## cat("dStartTime:   ", run$dStartTime, " \tdEndTime: ", run$dEndTime, "\n")
              }
              invisible(NULL)
          })

setMethod("isolationWindow", "mzRramp",
          function(object, ...) .isolationWindow(fileName(object), ...))
