#!/usr/bin/env bash
##
# populate project labels

# repository in format owner/repository
REPOSITORY="${REPOSITORY:-$1}"
# access token
ACCESS_TOKEN="${ACCESS_TOKEN:-$2}"
# delete existing labels
DELETE_EXISTING_LABELS="${DELETE_EXISTING_LABELS:-1}"

# array of labels
LABELS=(
  "bug"                 "d73a4a"          "Something isn't working"
  "documentation"       "0075ca"          "Improvements or additions to documentation"
  "duplicate"           "cfd3d7"          "Issue or pull request already exists"
  "feature"             "a2eeef"          "New feature or request"
  "help wanted"         "008672"          "Extra attention is needed"
  "invalid"             "e4e669"          "Doesn't seem right"
  "question"            "d876e3"          "Further information is requested"
  "task"                "7057ff"          "Task required to achieve goal"
  "wontfix"             "ffffff"          "Will not be worked on"
)

echo "Create configured labels."
echo "Personal access token is required to access private repositories."

# json value
jsonval(){
  local json="${1}"
  local prop="${2}"

  temp=$(echo "${json}" \
    | sed 's/\\\\\//\//g' \
    | sed 's/[{}]//g'    \
    | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' \
    | sed 's/\"\:\"/\|/g' \
    | sed 's/[\,]/ /g' \
    | grep -w "${prop}" \
    | cut -d":" -f2 \
    | sed -e 's/^ *//g' -e 's/ *$//g' \
  )
  temp="${temp//${prop}|/}"
  temp="$(echo "${temp}"|tr '\r\n' ' ')"

  echo "${temp}"
}

# uri encode
uriencode(){
  s="${1//'%'/%25}"
  s="${s//' '/%20}"
  s="${s//'"'/%22}"
  s="${s//'#'/%23}"
  s="${s//'$'/%24}"
  s="${s//'&'/%26}"
  s="${s//'+'/%2B}"
  s="${s//','/%2C}"
  s="${s//'/'/%2F}"
  s="${s//':'/%3A}"
  s="${s//';'/%3B}"
  s="${s//'='/%3D}"
  s="${s//'?'/%3F}"
  s="${s//'@'/%40}"
  s="${s//'['/%5B}"
  s="${s//']'/%5D}"
  printf %s "$s"
}

# timeout
timeout(){
  local seconds=${1}
  while [ "${seconds}" -gt 0 ]; do
    echo -ne "Processing will start in $seconds seconds. Press Ctrl+C to abort\033[0K\r"
    sleep 1
    : $((seconds--))
  done
}

# has user access
hasUserAccess(){
  status=$( \
    curl -s -I \
    -u "${ACCESS_TOKEN}":x-oauth-basic \
    --include -H "Accept: application/vnd.github.symmetra-preview+json" \
    -o /dev/null \
    -w "%{http_code}" \
    --request GET \
    "https://api.github.com/repos/${repositoryOwner}/${repositoryName}/labels" \
  )
  [ "${status}" == "200" ]
}

# is provided label
isProvidedLabel(){
  label="${1}"

  count=0
  for value in "${LABELS[@]}"; do
    if (( count % 3 == 0)); then
      name="${value}"
      if [ "${label}" == "${name}" ]; then
        return 0;
      fi
    fi
    count=$(( count + 1 ))
  done

  return 1
}

# is label exists
isLabelExists() {
  local name="${1}"
  local name_encoded=$(uriencode "${name}")
  status=$( \
    curl -s -I \
    -u "${ACCESS_TOKEN}":x-oauth-basic \
    --include -H "Accept: application/vnd.github.symmetra-preview+json" \
    -o /dev/null \
    -w "%{http_code}" \
    --request GET \
    "https://api.github.com/repos/${repositoryOwner}/${repositoryName}/labels/${name_encoded}" \
    )
  [ "${status}" == "200" ]
}

# get all labels
getAllLabel(){
  response=$( \
    curl -s \
    -u "${ACCESS_TOKEN}":x-oauth-basic \
    --include -H "Accept: application/vnd.github.symmetra-preview+json" \
    --request GET \
    "https://api.github.com/repos/${repositoryOwner}/${repositoryName}/labels" \
  )
  jsonval "${response}" "name"
}

# create label
createLabel(){
  local name="${1}"
  local color="${2}"
  local description="${3}"
  local status=$(curl -s \
    -u "${ACCESS_TOKEN}":x-oauth-basic \
    -H "Accept: application/vnd.github.symmetra-preview+json" \
    -o /dev/null \
    -w "%{http_code}" \
    --request POST \
    --data "{\"name\":\"${name}\",\"color\":\"${color}\", \"description\":\"${description}\"}" \
    "https://api.github.com/repos/${repositoryOwner}/${repositoryName}/labels" \
  )
  [ "${status}" == "201" ]
}

# update label
updateLabel(){
  local name="${1}"
  local color="${2}"
  local description="${3}"
  local name_encoded=$(uriencode "${name}")
  local status=$(curl -s \
    -u "${ACCESS_TOKEN}":x-oauth-basic \
    -H "Accept: application/vnd.github.symmetra-preview+json" \
    -o /dev/null \
    -w "%{http_code}" \
    --request PATCH \
    --data "{\"name\":\"${name}\",\"color\":\"${color}\", \"description\":\"${description}\"}" \
    "https://api.github.com/repos/${repositoryOwner}/${repositoryName}/labels/${name_encoded}" \
  )
  [ "${status}" == "200" ]
}

# delete label
deleteLabel(){
  local name="${1}"
  local color="${2}"
  local description="${3}"
  local name_encoded=$(uriencode "${name}")
  local status=$(curl -s \
    -u "${ACCESS_TOKEN}":x-oauth-basic \
    -H "Accept: application/vnd.github.symmetra-preview+json" \
    -o /dev/null \
    -w "%{http_code}" \
    --request DELETE \
    "https://api.github.com/repos/${repositoryOwner}/${repositoryName}/labels/${name_encoded}" \
  )
  [ "${status}" == "204" ]
}

# main method
main(){
  if [ "${DELETE_EXISTING_LABELS}" == "1" ]; then
    echo "Remove the default labels."
  else
    echo "Don't remove the default labels."
  fi

  # repository
  if [  "${REPOSITORY}" == "" ]; then
    echo 'Owner/Repository (e.g. foo/bar)'
    read -r REPOSITORY
  else
    REPOSITORY="$1"
  fi

  # access token
  if [  "${ACCESS_TOKEN}" == "" ]; then
    echo 'Access Token'
    read -r -s ACCESS_TOKEN
  fi

  # repository
  repositoryOwner=$(echo "$REPOSITORY" | cut -f1 -d /)
  repositoryName=$(echo "$REPOSITORY" | cut -f2 -d /)

  if ! hasUserAccess; then
    echo "User does not have access to specified repository. Please check your credentials" && exit 1
  fi

  echo "Starting label processing"

  timeout 3

  if [ "${DELETE_EXISTING_LABELS}" == "1" ]; then
    echo "Checking existing labels"
    existingLabelsStrings="$(getAllLabel)"
    IFS=$'\n' existingLabels=( $(xargs -n1 <<<"${existingLabelsStrings}") )
    for existingLabelName in "${existingLabels[@]}"; do
      if ! isProvidedLabel "${existingLabelName}"; then
        echo "Removing label \"${existingLabelName}\" as it is not in thr provided list"
        if deleteLabel "${existingLabelName}"; then
          echo "Deleted label \"${existingLabelName}\""
        else
          echo "Unable to delete label \"${existingLabelName}\""
        fi
      fi
    done
  fi

  count=0
  for value in "${LABELS[@]}"; do
    if (( count % 3 == 0)); then
      name="${value}"
    elif (( count % 3 == 1)); then
      color="${value}"
    else
      description="${value}"

      echo "Processing label \"${name}\""
      if isLabelExists "${name}"; then
        if updateLabel "${name}" "${color}" "${description}"; then
          echo "Updated label \"${name}\""
        else
          echo "Unable to update label \"${name}\""
        fi
      else
        if createLabel "${name}" "${color}" "${description}"; then
          echo "Created label \"${name}\""
        else
          echo "Unable to create label \"${name}\""
        fi
      fi

    fi
    count=$(( count + 1 ))
  done

  echo "Label processing complete"
}

main "$@"