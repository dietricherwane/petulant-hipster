class CustomerMailer < ActionMailer::Base
  #default from: "SmsGateway NGSER"

  def welcome_email(customer)
    @customer = customer
    @url  = 'de2513.ispfr.net:9999/customer/session'
    mail(to: @customer.email, subject: 'Création de votre compte - SmsGateway NGSER')
  end

  def send_email(email, obj, sender, content)
    @content = content

    mail(to: email, from: "#{sender} <dietricherwane@gmail.com>", subject: obj)
  end
end
