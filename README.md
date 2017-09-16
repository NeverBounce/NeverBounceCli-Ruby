
<p align="center"><img src="https://neverbounce-marketing.s3.amazonaws.com/neverbounce_color_600px.png"></p>

<p align="center">
  <a href="https://travis-ci.org/NeverBounce/NeverBounceCli-Ruby"><img src="https://travis-ci.org/NeverBounce/NeverBounceCli-Ruby.svg" alt="Build Status"></a>
  <a href="https://codeclimate.com/github/NeverBounce/NeverBounceCli-Ruby"><img src="https://codeclimate.com/github/NeverBounce/NeverBounceCli-Ruby/badges/gpa.svg" /></a>
</p>

NeverBounceCli-Ruby
===================

This is the official NeverBounce V4 CLI written in Ruby. See also:

* Our Ruby API gem: https://github.com/NeverBounce/NeverBounceApi-Ruby.
* Our full RubyDoc documentation: http://rubydoc.info/github/NeverBounce/NeverBounceCli-Ruby.

## Installation

In your `Gemfile`, add:

```ruby
gem "neverbounce-api", git: "https://github.com/NeverBounce/NeverBounceApi-Ruby.git"
gem "neverbounce-cli", git: "https://github.com/NeverBounce/NeverBounceCli-Ruby.git"
```

Install bundle, generate binstubs:

```sh
$ bundle install
$ bundle binstub neverbounce-cli

$ ls bin
nb-account-info  nb-jobs-delete    nb-jobs-parse    nb-jobs-search  nb-jobs-status
nb-jobs-create   nb-jobs-download  nb-jobs-results  nb-jobs-start   nb-single-check
```

Create `~/.neverbounce.yml`, add your API key there:

```yaml
api_key: key123abc
```

## Usage

Before we begin, here's just 2 things you need to know to become a happy NeverBounce CLI user:

1. Script names consistently map to our [REST API v4](https://developers.neverbounce.com/v4.0/).
  <br />For example, `nb-single-check` calls `single/check`, `nb-jobs-create` calls `jobs/create` and so on.
2. Every script supports `--help` and tells everything about itself.

Let's check a single e-mail:

```sh
$ bin/nb-single-check --help
nb-single-check - Check a single e-mail

USAGE: nb-single-check [options] [VAR1=value] [VAR2=value] ...

-h, --help                       Show help information

Environment variables:
* API_KEY      - API key ("2ed45186c72f9319dc64338cdf16ab76b44cf3d1")
* EMAIL        - E-mail to check ("tom@isp.com", "dick+1@domain.com")
- ADDRESS_INFO - Request additional address info ("y", "n")
- API_URL      - Custom API URL ("https://staging-api.isp.com/v5")
- CREDITS_INFO - Request additional credits info ("y", "n")
- CURL         - Print cURL request and exit ("y", ["N"])
- RAW          - Print raw response body ("y", ["N"])
- TIMEOUT      - Timeout in seconds to verify the address ("5")
```

Let's do it:

```sh
$ bin/nb-single-check EMAIL=support@neverbounce.com

Response:
+--------+------------------+----------+----------+
| Result |      Flags       | SuggCorr | ExecTime |
+--------+------------------+----------+----------+
| valid  | has_dns          |          |      651 |
|        | has_dns_mx       |          |          |
|        | role_account     |          |          |
|        | smtp_connectable |          |          |
+--------+------------------+----------+----------+

$ bin/nb-single-check EMAIL=support@neverbounce.com CREDITS_INFO=y

Response:
<...like above...>

CreditsInfo:
+---------+----------+---------+----------+
| FreeRmn | FreeUsed | PaidRmn | PaidUsed |
+---------+----------+---------+----------+
|     969 |        1 | 1000000 |        0 |
+---------+----------+---------+----------+

etc.
```

## Advanced usage

### Print cURL command with `CURL=y`

Each of our scripts can print command to make the request using native `curl` binary on your OS. For example:

```sh
$ bin/nb-single-check EMAIL=support@neverbounce.com CURL=y
curl --request GET --url https://api.neverbounce.com/v4/single/check --header Content-Type:\ application/json
--data-binary \{\"email\":\"support@neverbounce.com\",\"key\":\"key123abc\"\}
```

You can now pass this command around, use it in scripts etc.

### Print raw response with `RAW=y`

Each of our scripts can print raw server response without trying to decode it. For example:

```sh
$ bin/nb-single-check EMAIL=support@neverbounce.com RAW=y
{"status":"success","result":"valid","flags":["smtp_connectable","has_dns","has_dns_mx","role_account"],
"suggested_correction":"","execution_time":787}
```

Although primary users of this feature is us at NeverBounce, you can also benefit from it, e.g. if you encounter a server glitch and want to supply us a meaningful bug report.

## Compatibility

Minimum Ruby version is 2.0.

## Copyright

NeverBounce CLI in Ruby is free and is licensed under the MIT License.
Copyright &copy; 2017 NeverBounce.
