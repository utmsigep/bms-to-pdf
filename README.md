# BMS to PDF Tool

[![Run CI Tasks](https://github.com/utmsigep/bms-to-pdf/actions/workflows/ci.yml/badge.svg)](https://github.com/utmsigep/bms-to-pdf/actions/workflows/ci.yml) [![CodeQL](https://github.com/utmsigep/bms-to-pdf/actions/workflows/codeql-analysis.yml/badge.svg)](https://github.com/utmsigep/bms-to-pdf/actions/workflows/codeql-analysis.yml)

![Open Graph Image](public/opengraph.png)

Takes the CSV file exported from mySigEp's Balanced Man Scholarship tool to create a PDF of the applications, one per page.

[Demo](https://bms.sigep.network)

## Local Development

Install gems:

```
bundle install
```

Start the app:

```
bundle exec puma
```

The app will be available at http://localhost:9292.

## Testing

```
bundle exec rake test
```
