require 'exifr'
require 'fileutils'
require 'time'
require './JSONReader'
require 'Logger'

# initialize logging
time_now = Time.new.to_i
logger = Logger.new("logfile_#{time_now}.log")
logger.info('initialize') { "Logger started" }
  
begin  
  #load directories from properties.json
  propReader = JSONReader.new()
  source_dir = propReader.getSourceDir
  dest_dir = propReader.getDestDir
  
  logger.info('Quellordner') {"#{source_dir}"}
  logger.info('Zielordner') {"#{dest_dir}"}
  
  #all files in source_dir
  Dir.foreach(source_dir) do
    |file|
    extension = File.extname(file)
    file_name = file.chomp(extension)
    file_path = "#{source_dir}#{file_name}#{extension}"
    
    logger.info('File found') {"#{file_name}"}
    
    #check extension
    if (file_name == '.' || file_name == '..')
      logger.warn('wrong filename') {"#{file_path} will not be handled"}
    else
      logger.info('File found') {"#{file_path}"}
   
      #get timestamps
      dateTaken = nil
      mtime = File.new(file_path).mtime                          # modification time

      #check existence of timestamps
      if(mtime!=nil) 
        time = Time.parse(mtime.to_s)
      else
        logger.warn('loading date') {"Property 'Modification Time' is not set. Try to use 'Date taken'"}
        dateTaken = EXIFR::JPEG.new(file_path).date_time_original  # original date taken
        if(dateTaken != nil)
          time = Time.parse(dateTaken.to_s)
        else
          raise "missing property 'Date taken'. Could not rename file"
        end
      end
  
      #create new file name
      month = sprintf '%02d', time.month  #2-digit format
      day = sprintf '%02d', time.day      #2-digit format

      file_path_new = "#{dest_dir}#{month}_#{day}_#{file_name}#{extension}"
      unless file_path_new == file_path 
        #create new file with same mtime (date taken is equal by default)
        FileUtils.copy_file(file_path, file_path_new)
        logger.info('File copied') {"#{file_path_new}"}
        FileUtils.touch file_path_new, :mtime => mtime
        logger.info('File touched') {"#{file_path_new}"}
      end
    end
  end
  rescue => err
    logger.fatal('Error') {"Exception: #{err}"}
    err
end
  