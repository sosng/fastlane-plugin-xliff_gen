module Fastlane
  module Actions
    module SharedValues
      XE_XLIFF_LOCATION = :XE_XLIFF_LOCATION
    end
    class XliffEnGenAction < Action
      def self.run(params)

        require 'nokogiri'
        
        projectPath = File.absolute_path(params[:xcodeproj])
        
        UI.message("Located project at: "+projectPath)

        workingPath = File.dirname(projectPath)

        dir = File.dirname(projectPath)
        
        file = File.basename(projectPath)
  
        sh ("cd #{dir} && xcodebuild -exportLocalizations -localizationPath #{workingPath} -project #{file} -exportLanguage en")

        xliffPath = File.join(workingPath, "en.xliff")

        Actions.lane_context[SharedValues::XE_XLIFF_LOCATION] = xliffPath
        
        doc = Nokogiri::XML(File.open(xliffPath))

        doc.remove_namespaces!

        UI.message("Found total: "+doc.xpath("count(//file[@original='uan/en.lproj/Localizable.strings']/body/trans-unit)").to_s()+" translation unit")

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

        UI.message("Localizable moved to: "+localizablePath)

        keepFile = params[:keepArtifacts]
        
        if not keepFile
          FileUtils.rm xliffPath, :force => true
        end 
      
      end



      def self.description
        "Overwrite project Localizable.strings file from English version xliff"
      end

      def self.authors
        ["alexander sun"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end
      def self.output
        [
          ['XE_XLIFF_LOCATION', 'Path to en.xliff']
        ]
      end

      def self.details
        "Generate new Localizable.strings file based on the exported en.xliff by using xcode build, and over write the file based on the en.xliff.\n This will include nokogiri to parse xml.
        lane context XE_XLIFF_LOCATION will be used for store location of the en.xliff"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :xcodeproj,
                             env_name: "XLIFF_EN_GEN_PROJECT",
                             description: "Specify the path to your main Xcode project",
                             optional: false,
                             type: String,
                             verify_block: proc do |value|
                               UI.user_error!("Please specify your project file path") if !value.end_with? ".xcodeproj"
                               UI.user_error!("Could not find Xcode project at path '#{File.expand_path(value)}'") if !File.exist?(value) and !Helper.is_test?
                             end),
          FastlaneCore::ConfigItem.new(key: :localizable,
                             env_name: "XLIFF_EN_GEN_LOCALIZABLE_PATH",
                             description: "localizable.strings path to be replaced",
                             optional: false,
                             type: String,
                             verify_block: proc do |value|
                               UI.user_error!("Could not find Localizable.strings project at path '#{File.expand_path(value)}'") if !File.exist?(value) and !Helper.is_test?
                             end),
          FastlaneCore::ConfigItem.new(key: :keepArtifacts,
                             env_name: "XLIFF_EN_GEN_KEEP_ARTIFACTS",
                             description: "whether keep the en.xliff file for your use",
                             optional: true,
                             default_value: false,
                             type: TrueClass)
        ]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
        true
      end
    end
  end
end
