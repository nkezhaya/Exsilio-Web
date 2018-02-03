Aws.config.update({
  region: "us-east-1",
  credentials: Aws::Credentials.new(Figaro.env.s3_access_key, Figaro.env.s3_access_secret)
})
