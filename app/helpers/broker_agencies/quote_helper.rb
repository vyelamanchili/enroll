module BrokerAgencies::QuoteHelper
	def draft_quote_header(state)
		if state == "draft"
			content_tag(:h3, "Review: Publish your Quote" )+
			content_tag(:span, "Please review the information below before publishing your quote. Once the quote is published, no information can be changed.") 
		end
	end
end