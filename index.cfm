<cfset accessKey = "YOUR_ACCESS_KEY">
<cfset secretKey = "YOUR_SECRET_KEY">
<cfset region = "us-east-1">
<cfset service = "s3">
<cfset httpMethod = "GET">
<cfset canonicalUri = "/example-bucket/example-object">
<cfset canonicalQueryString = "">

<!--- Step 1: Create a timestamp in ISO 8601 format --->
<cfset now = now()>
<cfset timestamp = dateConvert("utc2Local", now)>
<cfset timestamp = dateConvert("local2Utc", timestamp)>
<cfset timestamp = dateFormat(timestamp, "yyyy-mm-dd'T'HH:mm:ss'Z'")>

<!--- Step 2: Create a date string in YYYYMMDD format --->
<cfset dateStamp = dateFormat(timestamp, "yyyymmdd")>

<!--- Step 3: Create the canonical headers string --->
<cfset canonicalHeaders = "host:#cgi.HTTP_HOST#&#chr(10)#x-amz-date:#timestamp#&#chr(10)#">

<!--- Step 4: Create the signed headers string --->
<cfset signedHeaders = "host;x-amz-date">

<!--- Step 5: Create the canonical request string --->
<cfset canonicalRequest = "#httpMethod#&#chr(10)##canonicalUri#&#chr(10)##canonicalQueryString#&#chr(10)##canonicalHeaders#&#chr(10)##signedHeaders#&#chr(10)#UNSIGNED-PAYLOAD">

<!--- Step 6: Create the string to sign --->
<cfset algorithm = "AWS4-HMAC-SHA256">
<cfset credentialScope = "#dateStamp#/#region#/#service#/aws4_request">
<cfset stringToSign = "#algorithm#&#chr(10)##timestamp#&#chr(10)##credentialScope#&#chr(10)##hash(canonicalRequest)#">

<!--- Step 7: Create the signing key --->
<cfset kDate = hmac("AWS4#secretKey#", dateStamp, "HmacSHA256")>
<cfset kRegion = hmac(kDate, region, "HmacSHA256")>
<cfset kService = hmac(kRegion, service, "HmacSHA256")>
<cfset kSigning = hmac(kService, "aws4_request", "HmacSHA256")>

<!--- Step 8: Create the signature --->
<cfset signature = toBase64(hmac(kSigning, stringToSign, "HmacSHA256"))>

<!--- Step 9: Create the authorization header --->
<cfset authorizationHeader = "#algorithm# Credential=#accessKey#/#credentialScope#, SignedHeaders=#signedHeaders#, Signature=#signature#">

<!--- Include the authorization header in your API request --->
<cfhttp method="#httpMethod#" url="https://s3.amazonaws.com#canonicalUri#" result="response">
    <cfhttpparam type="header" name="Host" value="#cgi.HTTP_HOST#">
    <cfhttpparam type="header" name="x-amz-date" value="#timestamp#">
    <cfhttpparam type="header" name="Authorization" value="#authorizationHeader#">
</cfhttp>
