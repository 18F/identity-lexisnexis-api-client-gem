describe LexisNexis::DateFormatter do
  describe '#formatted_date' do
    subject { described_class.new(date_string) }

    context 'with a MM/DD/YYYY formatted date' do
      let(:date_string) { '01/02/1993' }

      it 'returns a properly formatted date hash' do
        expect(subject.formatted_date).to eq(
          Year: '1993',
          Month: '1',
          Day: '2'
        )
      end
    end

    context 'with a YYYYMMDD formatted date' do
      let(:date_string) { '19930102' }

      it 'returns a properly formatted date hash' do
        expect(subject.formatted_date).to eq(
          Year: '1993',
          Month: '1',
          Day: '2'
        )
      end
    end
  end
end
