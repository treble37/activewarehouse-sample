#if !Rails.env.production?
#  dropbox_config = YAML.load_file("#{Rails.root.to_s}/config/dropbox.yml")
#  ENV['DROPBOX_ACCESS_TOKEN'] = dropbox_config['DROPBOX_ACCESS_TOKEN']
#end
#client = DropboxClient.new(ENV['DROPBOX_ACCESS_TOKEN'])
#file_data, metadata = client.get_file_and_metadata('/ehome/DataNexus/People/data.csv')


file = File.expand_path(File.dirname(__FILE__)+'/lib/data.csv')

source :input,
  {
    :file => file,
    :parser => :csv,
    :skip_lines => 1
  },
  [
    :first_name,
    :last_name,
    :era_commons_id,
    :email,
    :phone,
    :title,
    :faculty_series,
    :affiliation,
    :school,
    :department
  ]

transform(:email_provider) do |n,v,r|
  r[:email].downcase.split('@').last
end

transform :email_provider, :default,
  :default_value => "Unknown"

transform(:full_name) do |n,v,r|
  [r[:first_name], r[:last_name]].join(' ')
end


destination :out, {
  :file => 'dummy.txt'
},
{
  :primarykey => [:email],
  :order => [:email, :full_name, :email_provider]
}

