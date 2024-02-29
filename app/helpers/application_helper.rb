module ApplicationHelper
    def float_to_percent(float_value)
        sprintf('%.2f%%', float_value * 100)
    end
end
