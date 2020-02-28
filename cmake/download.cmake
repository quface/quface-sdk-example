function(download_file url filename hash_type hash)
  message(STATUS "Download ${url} to ${filename} ...")
  file(
    DOWNLOAD ${url} ${filename}
    TIMEOUT 600 # seconds
    EXPECTED_HASH ${hash_type}=${hash})
endfunction()

function(download_and_extract url filename hash_type hash extract_dir)
  if(NOT EXISTS ${filename})

    download_file(${url} ${filename} ${hash_type} ${hash})

  else()

    file(${hash_type} ${filename} _CHKSUM)
    if(NOT ${_CHKSUM} STREQUAL ${hash})
      message(WARNING "File hash miss match ...")
      file(REMOVE ${filename})
      download_file(${url} ${filename} ${hash_type} ${hash})
    endif()

  endif()

  if(EXISTS ${extract_dir})
    file(REMOVE_RECURSE ${extract_dir})
  endif()

  message(STATUS "Extract ${filename} to ${extract_dir} ...")

  set(temp_dir ${CMAKE_BINARY_DIR}/tmp_for_extract.dir)
  execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${temp_dir})
  execute_process(COMMAND ${CMAKE_COMMAND} -E tar -xf ${filename}
                  WORKING_DIRECTORY ${temp_dir})

  file(GLOB contents "${temp_dir}/*")
  list(LENGTH contents n)
  if(NOT n EQUAL 1 OR NOT IS_DIRECTORY "${contents}")
    set(contents "${temp_dir}")
  endif()

  get_filename_component(contents ${contents} ABSOLUTE)
  file(RENAME ${contents} ${extract_dir})
  file(REMOVE_RECURSE ${temp_dir})

endfunction()
