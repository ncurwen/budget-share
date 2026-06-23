module PaginationHelper
  include Pagy::Frontend

  # DaisyUI-styled replacement for Pagy's default nav. Renders a centered `join`
  # of buttons; returns nil when there's only a single page.
  def pagy_nav(pagy)
    return if pagy.pages == 1

    html = [ %(<div class="w-full justify-center join" aria-label="Pages">) ]
    html << if pagy.prev
      prev_url = pagy_url_for(pagy, pagy.prev)
      %(<a href="#{prev_url}" class="join-item btn tooltip" aria-label="Previous" data-tip="Previous Page" data-turbo-action="replace">«</a>)
    else
      %(<button class="join-item btn btn-disabled" aria-disabled="true" aria-label="Previous">«</button>)
    end
    pagy.series.each do |item|
      case item
      when Integer
        page_url = pagy_url_for(pagy, item)
        html << %(<a href="#{page_url}" class="join-item btn tooltip" data-tip="Go to Page #{item}" data-turbo-action="replace">#{item}</a>)
      when String
        html << %(<button class="join-item btn btn-active cursor-default" aria-disabled="true" aria-current="page">#{item}</button>)
      when :gap
        html << %(<button class="join-item btn btn-disabled" aria-disabled="true">...</button>)
      end
    end
    html << if pagy.next
      next_url = pagy_url_for(pagy, pagy.next)
      %(<a href="#{next_url}" class="join-item btn tooltip" aria-label="Next" data-tip="Next Page" data-turbo-action="replace">»</a>)
    else
      %(<button class="join-item btn btn-disabled" aria-disabled="true" aria-label="Next">»</button>)
    end
    html << %(</div>)
    html.join.html_safe
  end
end
