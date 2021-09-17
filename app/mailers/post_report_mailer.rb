class PostReportMailer < ApplicationMailer
    def post_report(user, post, post_report)
        @user = user
        @post = post
        @post_report = post_report
        mail(to: @user.email, subject: 'Post Report')
    end
end
