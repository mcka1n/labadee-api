namespace :add do
  namespace :client do
    desc "[clients rake] Adds new API client"
    task :for, [:client_name] => :environment do |t, args|
      args.with_defaults(:client_name => 'w00t')
      if args.client_name != "w00t"
        client = Client.new
        client.name = args.client_name
        if client.save
          puts "[success] #{client.name} with key: #{client.key}"
        else
          puts "[error] #{client.errors.messages}"
        end
      else
        puts "Error: Fail !!"
        puts "  You gotta do something like this: "
        puts "  rake add:client:for[--insert client name here--]"
      end
    end
  end
end
