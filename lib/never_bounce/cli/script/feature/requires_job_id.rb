
module NeverBounce; module CLI; module Script; module Feature
  # Common traits for scripts which require job ID.
  # @see InstanceMethods
  module RequiresJobId
    # @param owner [Class]
    # @return [nil]
    def self.load(owner)
      return if owner < InstanceMethods
      owner.send(:include, InstanceMethods)

      owner.class_eval do
        attr_writer :job_id

        envar "ID", "Job ID", ["276816"]
      end
    end

    module InstanceMethods
      # Job ID. Default is <tt>env["ID"]</tt>.
      # @!attribute job_id
      # @return [String]
      def job_id
        @job_id ||= env[k = "ID"] or raise UsageError, "Job ID not given, use `#{k}=`"
      end
    end
  end
end; end; end; end
