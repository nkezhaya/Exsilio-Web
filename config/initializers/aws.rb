AWS.config({
  access_key_id: Figaro.env.s3_access_key,
  secret_access_key: Figaro.env.s3_access_secret
})
