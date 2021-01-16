#!/usr/bin/env bash
set -eo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

in_file=market-extensions.txt
out_file=market-extensions.nix

echo "{ extensionFromVscodeMarketplace }: [" >"$out_file"
while IFS="." read -r publisher name; do
    echo "Fetching '$publisher'.'$name'"

    version=$(
        curl --silent 'https://marketplace.visualstudio.com/_apis/public/gallery/extensionquery' \
            --compressed \
            -H 'Accept: application/json;api-version=6.1-preview.1;excludeUrls=true' \
            -H 'Content-Type: application/json' \
            --data-raw '{"assetTypes":null,"filters":[{"criteria":[{"filterType":7,"value":"'$publisher.$name'"}],"direction":2,"pageSize":1,"pageNumber":1,"sortBy":0,"sortOrder":0,"pagingToken":null}],"flags":103}' \
        | jq '.results | .[0].extensions | .[0].versions | .[0].version' -r
    )

    url="https://$publisher.gallery.vsassets.io/_apis/public/gallery/publisher/$publisher/extension/$name/$version/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage"
    hash=$(nix-prefetch-url --type sha256 --name "$publisher-$name.zip" "$url")

    cat >> "$out_file" <<EOF
  (extensionFromVscodeMarketplace {
    publisher = "$publisher";
    name = "$name";
    version = "$version";
    sha256 = "$hash";
  })
EOF
done <"$in_file"
echo "]" >>"$out_file"
