module Amorail

  module MethodMissing
    def method_missing(method_sym, *arguments, &block)
      if data.has_key?(method_sym.to_s)
        data.fetch(method_sym.to_s)
      else
        super
      end
    end
  end

  class Property

    class PropertyItem
      include MethodMissing

      def initialize(data)
        @data = data
      end

      def data
        @data
      end
    end
    
    def initialize(client)
      @client = client
      @data = load_fields
    end

    def client
      @client
    end

    def data
      @data
    end

    def load_fields
      response = client.safe_request(:get, '/private/api/v2/json/accounts/current')
      response.body["response"]["account"] 
    end

    def contacts
      Contact.parse(data)
    end

    def companies
      Company.parse(data)
    end

    def leads
      Lead.parse(data)
    end

    def tasks
      Task.parse(data)
    end

    class Contact
      include MethodMissing

      def initialize(data)
        @data = data
      end

      def data
        @data
      end

      def self.parse(data)
        hash = {}
        data['custom_fields']['contacts'].each do |contact|
          hash[contact['code'].downcase] = PropertyItem.new(contact)
        end
        new hash
      end
    end

    class Company
      include MethodMissing

      def initialize(data)
        @data = data
      end

      def data
        @data
      end

      def self.parse(data)
        hash = {}
        data['custom_fields']['companies'].each do |company|
          hash[company['code'].downcase] = PropertyItem.new(company)
        end
        new hash
      end
    end

    class Lead
      include MethodMissing

      def initialize(data)
        @data = data
      end

      def data
        @data
      end

      def self.parse(data)
        hash = {"first_status" => PropertyItem.new(data['leads_statuses'].first)}
        new hash
      end
    end

    class Task
      include MethodMissing

      def initialize(data)
        @data = data
      end

      def data
        @data
      end

      def self.parse(data)
        hash = {}
        data['task_types'].each do |tt|
          hash[tt['code'].downcase] = PropertyItem.new(tt)
        end
        new hash
      end
    end
  end
end