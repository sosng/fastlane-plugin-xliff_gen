module Fastlane
  module Actions
    module SharedValues
      XE_XLIFF_LOCATION = :XE_XLIFF_LOCATION
    end
    class ExportXliffAction < Action
      def self.run(params)

        projectPath = File.absolute_path(params[:xcodeproj])
        
        UI.message("Located project at: "+projectPath)

        workingPath = File.dirname(projectPath)

        dir = File.dirname(projectPath)
        
        file = File.basename(projectPath)
  
        sh ("cd #{dir} && xcodebuild -exportLocalizations -localizationPath #{workingPath} -project #{file} -exportLanguage en")

        xliffPath = File.join(workingPath, "en.xliff")

        Actions.lane_context[SharedValues::XE_XLIFF_LOCATION] = xliffPath
      
        xliffPath
      end



      def self.description
        "export xliff for an xcode project"
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
        "using "
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
          FastlaneCore::ConfigItem.new(key: :exportLanguage,
                             env_name: "XLIFF_EN_GEN_LANGUAGE",
                             description: "target language",
                             optional: true,
                             type: String,
                             default_value: "en")
        ]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
        true
      end
    end
  end
end
