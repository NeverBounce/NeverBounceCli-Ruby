
module NeverBounce; module CLI; module Script; module Feature
  # Common traits for scripts which support pagination.
  # @see InstanceMethods
  module UsesPagination
    # @param owner [Class]
    # @return [nil]
    def self.load(owner)
      return if owner < InstanceMethods
      owner.send(:include, InstanceMethods)

      owner.class_eval do
        attr_writer :page, :per_page

        envar "PAGE", "Fetch page number N", [{default: 1}, 5]
        envar "PER_PAGE", "Paginate results N items per page", [10, default: 1000]
      end
    end

    module InstanceMethods
      # Page number. Default is <tt>env["PAGE"]</tt>.
      # @!attribute page
      # @return [Integer]
      def page
        # OPTIMIZE: Consider default-less behaviour some day.
        @page ||= if (v = env["PAGE"])
          Integer(v)
        else
          1
        end
      end

      # Items per page. Default is <tt>env["PER_PAGE"]</tt>.
      # @!attribute per_page
      # @return [Integer]
      def per_page
        @per_page ||= if (v = env["PER_PAGE"])
          Integer(v)
        else
          1000
        end
      end
    end
  end
end; end; end; end
