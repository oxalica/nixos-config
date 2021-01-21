#!/usr/bin/env bash
set -eo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/home/modules/vscode"
in_file=market-extensions.txt
out_file=market-extensions.nix
tmp_file="$out_file.tmp"

case "$1" in
  "")
    ;;
  --update)
    update=1
    ;;
  *)
    echo "Usage: $0 [--update]"
    exit 1
esac

declare -A cache
if [[ -f "$out_file" ]]; then
  while read -r publisher; do
    read name; read version; read hash
    cache["$publisher.$name"]="$version $hash"
  done < <(sed -nE 's/^\s*\w+ = "(.*)";$/\1/p' "$out_file")
fi

echo "{ extensionFromVscodeMarketplace }: [" >"$tmp_file"
while IFS="." read -r publisher name; do
  read -r version hash <<<"${cache["$publisher.$name"]}"
  if [[ -z "$version" || -v update ]]; then
    echo "Fetching latest version of $publisher.$name"
    new_version="$(
      curl -sS --compressed \
        'https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery' \
        -H 'Accept: application/json;api-version=6.1-preview.1;excludeUrls=true' \
        -H 'Content-Type: application/json' \
        --data-raw '{"assetTypes":null,"filters":[{"criteria":[{"filterType":7,"value":"'$publisher.$name'"}],"direction":2,"pageSize":1,"pageNumber":1,"sortBy":0,"sortOrder":0,"pagingToken":null}],"flags":103}' \
      | jq '.results | .[0].extensions | .[0].versions | .[0].version' -r
    )"

    if [[ "$version" != "$new_version" ]]; then
      version="$new_version"
      url="https://$publisher.gallery.vsassets.io/_apis/public/gallery/publisher/$publisher/extension/$name/$version/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage"
      hash=$(nix-prefetch-url --type sha256 --name "$publisher-$name.zip" "$url")
    fi
  fi

  cat >> "$tmp_file" <<EOF
  (extensionFromVscodeMarketplace {
    publisher = "$publisher";
    name = "$name";
    version = "$version";
    sha256 = "$hash";
  })
EOF
done <"$in_file"
echo "]" >>"$tmp_file"
mv -T "$tmp_file" "$out_file"
