# slack-ruby-clientとかはどうもwebhookサポートしてないんですよね
# だからシンプルなラッパーを使います
# まあHTTP直に書いても良いのですが、読みにくいので嫌でした
require 'slack/incoming/webhooks'

Plugin.create :post_it_with_slack do
  UserConfig[:post_it_with_slack_webhook] ||= ''

  # as_userはtoken取得しないと使えない
  # 仕事ならともかくこんなくだらないことに読み込み出来るセキュリティとか気にしたくない
  # マルチポストはそうと分かったほうが良いという側面もあります
  slack = Slack::Incoming::Webhooks.new UserConfig[:post_it_with_slack_webhook]

  command(
    :post_it_with_slack,
    name: 'WorldとSlackに同時投稿',
    condition: ->(opt) { opt.widget&.editable? },
    visible: true,
    icon: Skin[:post],
    role: :postbox
  ) do |opt|
    text = ::Plugin.create(:gtk).widgetof(opt.widget).widget_post.buffer.text
    opt.widget.post_it!(world: opt.world) # Twitterへの投稿成功を判定していないのでSlackだけに投稿されることがあります
    slack.post text
  end

  settings 'WorldとSlackに同時投稿' do
    # URLバリデーションとかしたい
    input('webhook', :post_it_with_slack_webhook)
  end
end
