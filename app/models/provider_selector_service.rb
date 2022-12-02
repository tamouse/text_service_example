# frozen_string_literal: true

class ProviderSelectorService
  attr_reader :providers

  def self.provider
    new.provider
  end

  def initialize
    @providers = Provider.where(status: Provider::STATUS_ACTIVE)
  end

  def provider
    weighted_randomizer
  end

  def weighted_randomizer
    weighted_sum = providers.pluck(:weight).reduce(:+)
    providers.each do |p|
      p.update(weight: p.weight / weighted_sum)
    end
    providers.max_by { |p| rand ** (1.0 / p.weight) }
  end
end
