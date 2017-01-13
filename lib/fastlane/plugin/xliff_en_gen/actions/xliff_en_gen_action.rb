module Fastlane
  module Actions
    class XliffEnGenAction < Action
      def self.run(params)
        require 'nokogiri'
        
        projectPath = File.absolute_path(params[:xcodeproj])
        
        workingPath = File.dirname(projectPath)

        dir = File.dirname(projectPath)
        
        file = File.basename(projectPath)
  
        sh ("cd #{dir} && xcodebuild -exportLocalizations -localizationPath #{workingPath} -project #{file} -exportLanguage en")

        xliffPath = File.join(workingPath, "en.xliff")
        
        doc = Nokogiri::XML(File.open(xliffPath))

        doc.remove_namespaces!

        UI.message("Found: "+doc.xpath("count(//file[@original='uan/en.lproj/Localizable.strings']/body/trans-unit)").to_s()+" translation unit")

        transUnits = doc.xpath("//file[contains(@original,'Localizable.strings')]/body/trans-unit")

        translations  =  Array.new 

        transUnits.each do |unit|

        transId = unit['id']

        target =  unit.at_xpath("target/text()")

        note =  unit.at_xpath("note/text()")

        if note == nil
          note = "(No Commment)"
        end

        info = { "id" => transId, "English" => target, "note" => note  }

        translations << info

        end

        translations.sort! {|x,y| x['id'] <=> y ['id']}


        File.open("Localizable.strings", "w"){ |f|

        translations.each do |transInfo|

        f.write ('/* ' + transInfo['note'] + ' */' + "\n")
        f.write ('"' + transInfo['id'] + '"' + "=" '"' + transInfo['English'] + '";' + "\n")
        f.write ("\n")

        end

        }


        localizablePath = params[:localizable]

        FileUtils.mv 'Localizable.strings', localizablePath, :force => true

        FileUtils.rm xliffPath, :force => true

      end



      def self.description
        "gen Localizable.strings file from xliff"
      end

      def self.authors
        ["alexander sun"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "generate new Localizable.strings file based on export en.xliff"
      end

      def self.available_options
        [
          # FastlaneCore::ConfigItem.new(key: :your_option,
          #                         env_name: "XLIFF_EN_GEN_YOUR_OPTION",
          #                      description: "A description of your option",
          #                         optional: false,
          #                             type: String)
          FastlaneCore::ConfigItem.new(key: :xcodeproj,
                             env_name: "XLIFF_EN_GEN_PROJECT",
                             description: "optional, you must specify the path to your main Xcode project if it is not in the project root directory",
                             optional: true,
                             type: String,
                             verify_block: proc do |value|
                               UI.user_error!("Please pass the path to the project, not the workspace") if value.end_with? ".xcworkspace"
                               UI.user_error!("Could not find Xcode project at path '#{File.expand_path(value)}'") if !File.exist?(value) and !Helper.is_test?
                             end),
          FastlaneCore::ConfigItem.new(key: :localizable,
                             env_name: "XLIFF_EN_GEN_LOCALIZABLE_PATH",
                             description: "localizable path to replace",
                             optional: false,
                             type: String,
                             verify_block: proc do |value|
                               UI.user_error!("Could not find Localizable.strings project at path '#{File.expand_path(value)}'") if !File.exist?(value) and !Helper.is_test?
                             end)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Platforms.md
        #
        [:ios, :mac].include?(platform)
        true
      end
    end
  end
end
