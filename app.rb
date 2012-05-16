# -*- coding: utf-8 -*-
require 'sinatra'
require 'qrselect'
require 'json'

QRSelect.config('./qrselect.conf')

set :server, :thin
before do
  content_type 'application/json'
end

get '/' do
  keywords = params[:k]
  tmp = {}
  params.each do |k, v|
    case k
    when 'limit'
      tmp[:limit] = v.to_i
    when 'recursive'
      tmp[:recursive] = v
    when 'expand'
      tmp[:expand] = v
    when 'domain'
      tmp[:domain] = v
    end
  end
  stream do |out|
    QRSelect.fetch(keywords, tmp) do |result|
      en_text = result.highest_score_text
      out << { 
        :ja_url => result.seed.url,
        :ja_title => result.seed.title,
        :en_url => en_text.url,
        :en_title => en_text.title,
      }.to_json + "\n"
    end
  end
end
