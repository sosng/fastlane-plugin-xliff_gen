describe Fastlane::Actions::XliffEnGenAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The xliff_en_gen plugin is working!")

      Fastlane::Actions::XliffEnGenAction.run(nil)
    end
  end
end
