module Fastlane
  module Helper
    class XliffEnGenHelper
      # class methods that you define here become available in your action
      # as `Helper::XliffEnGenHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the xliff_en_gen plugin helper!")
      end
    end
  end
end
