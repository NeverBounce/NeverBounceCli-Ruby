
module NeverBounce; module CLI; module Script; class JobsCreate
  describe SuppliedInputParser do
    include_dir_context __dir__

    describe "#separator" do
      it "generally works" do
        expect(newo.separator).to eq /[;,\n]/
        expect(newo(separator: ";").separator).to eq ";"
      end
    end

    describe "#process" do
      it "generally works" do
        # Invalid input.
        [
          ["", ArgumentError, /\bempty\b/i],
        ].each do |input, *raise_args|
          expect {newo[input]}.to raise_error(*raise_args)
        end

        # Valid input.
        [
          ["abc", [["abc", ""]]],
          ["  abc   def   ", [["abc", "def"]]],
          ["tom@isp.com Tom User;dick@gmail.com Dick Other", [["tom@isp.com", "Tom User"], ["dick@gmail.com", "Dick Other"]]],
          ["  tom@isp.com Tom User  ; dick@gmail.com  Dick Other  ", [["tom@isp.com", "Tom User"], ["dick@gmail.com", "Dick Other"]]],
          ["tom@isp.com Tom  User;,\n", [["tom@isp.com", "Tom  User"]]],
        ].each do |input, expected|
          expect([input, newo[input]]).to eq [input, expected]
        end
      end
    end
  end
end; end; end; end
