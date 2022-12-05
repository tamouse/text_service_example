# frozen_string_literal: true

class ProviderSelectorService
  attr_reader :providers, :except

  def self.provider(except: [])
    new(except: except).provider
  end

  # @param [Array<Integer>] array of provider IDs to exclude from the search
  def initialize(except: [])
    @except = except
    @providers = Provider.active.where.not(id: except)
  end

  def provider
    weighted_randomizer
  end

  def weighted_randomizer
    weighted_sum = providers.pluck(:weight).reduce(:+)
    normalized_list = providers.map do |p|
      { id: p.id, weight: p.weight / weighted_sum}
    end
    winner = normalized_list.max_by { |p| rand ** (1.0 / p[:weight]) }
    Provider.find_by(id: winner[:id]) if winner.present?
  end
end
