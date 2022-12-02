# frozen_string_literal: true

class ProviderSelectorServiceTest < ActiveSupport::TestCase
  test "the service instance has all the providers" do
    service = ProviderSelectorService.new
    refute_nil service.providers
    assert_equal Provider.count, service.providers.length
  end

  test "the weighted_randomizer picks a provider" do
    service = ProviderSelectorService.new
    provider = service.weighted_randomizer
    refute_nil provider
  end

  test "let's try the weighted_randomizer a lot and see what it does" do
    service = ProviderSelectorService.new
    freq = Hash.new(0)
    1000.times do |_i|
      p = service.weighted_randomizer
      freq[p.id] += 1
    end
    providers.each do |p|
      puts "p.id=#{p.id}, p.weight: #{p.weight}, freq[p.id]=#{freq[p.id]}, freq[p.id].to_f / 1000.0=#{freq[p.id].to_f / 1000.0}"
      assert_in_delta p.weight, freq[p.id].to_f / 1000.0, 0.01
    end
  end
end
