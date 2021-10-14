#!/bin/bash -e
# Copyright 2021 WSO2 Inc. (http://wso2.org)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# ----------------------------------------------------------------------------
# Execusion script for ballerina performance tests
# ----------------------------------------------------------------------------
set -e
source base-scenario.sh

jmeter -n -t "$scriptsDir/"http-get-request.jmx -l "$resultsDir/"original.jtl -Jusers="$concurrent_users" -Jduration=1200 -Jhost=bal.perf.test -Jport=80 -Jprotocol=http -Jpath=hello $payload_flags

echo "--------Processing Results--------"
pushd ../results/
echo "--------Splitting Results--------"
jtl-splitter.sh -- -f original.jtl -t 120 -u SECONDS -s
echo "--------Splitting Completed--------"

echo "--------Generating CSV--------"
JMeterPluginsCMD.sh --generate-csv summary.csv --input-jtl original-measurement.jtl --plugin-type AggregateReport
echo "--------CSV generated--------"

echo "--------Merge CSV--------"
create-csv.sh summary.csv ~/"${repo_name}"/load-tests/"$scenario_name"/results/summary.csv "$payload_size" "$concurrent_users"
echo "--------CSV merged--------"
popd