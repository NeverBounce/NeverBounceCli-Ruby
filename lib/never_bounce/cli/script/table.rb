
require "terminal-table"

module NeverBounce; module CLI; module Script
  # Our custom table class.
  class Table < Terminal::Table
    # Align table rows according to headings spec.
    #
    #   headings = [
    #     ["Status", :status],
    #     ["Completed", :completed, :right],
    #     ["Processing", :processing, :right],
    #   ]
    #
    #   table = Table.new(headings: ..., rows: ...).align!(headings)
    #   puts table
    #
    # NOTE: Invoke <b>after</b> adding row data.
    #
    # @return [self]
    def align!(headings)
      headings.each_with_index do |ar, i|
        if (v = ar[2])
          align_column(i, v)
        end
      end

      self
    end

    # Center-align headings by default.
    # @return [void]
    def headings=(ar)
      super(ar.map do |item|
        if item.is_a? String
          {value: item, alignment: :center}
        else
          item
        end
      end)
    end
  end
end; end; end
