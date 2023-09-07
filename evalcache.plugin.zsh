# Caches the output of a binary initialization command, to avoid the time to
# execute it in the future.
#
# Usage: _evalcache [NAME=VALUE]... COMMAND [ARG]...

# default cache directory
ZSH_EVALCACHE_DIR=${ZSH_EVALCACHE_DIR:-${HOME}/.zsh-evalcache}

# default hash method
ZSH_EVALCACHE_HASH=$(command -v md5sum || command -v md5)

function _evalcache {
  if [[ ${ZSH_EVALCACHE_DISABLE} == "true" ]]; then
    source <(eval ${(q)@})
    return
  fi

  local name typeDef cmdHash cacheFile

  # use the first non-variable argument as the name
  for name in $@; do
    if [[ ${name} == "${name#[A-Za-z_][A-Za-z0-9_]*=}" ]]; then
      break
    fi
  done

  typeDef=$(type -fs ${name})

  if (( $? )); then
    print "evalcache: ERROR: ${name} is not installed or not in PATH" >&2
    return 1
  fi

  if [[ -n ${ZSH_EVALCACHE_HASH} ]]; then
    cmdHash=$(${ZSH_EVALCACHE_HASH} <<< "$*:${typeDef}")
  else
    cmdHash="nohash"
  fi

  cacheFile="${ZSH_EVALCACHE_DIR}/init-${name##*/}-${cmdHash%% *}.sh"

  if [[ ! -s ${cacheFile} ]]; then
    print "evalcache: ${name} initialization not cached, caching output of: $*" >&2
    mkdir -p ${ZSH_EVALCACHE_DIR}
    eval ${(q)@} > ${cacheFile}
  fi

  source ${cacheFile}
}

function _evalcache_clear {
  rm -i $@ ${ZSH_EVALCACHE_DIR}/init-*.sh
}
